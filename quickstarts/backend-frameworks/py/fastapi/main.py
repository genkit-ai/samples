from datetime import datetime
from typing import Literal

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from genkit import ActionRunContext, Genkit
from genkit.plugins.fastapi import genkit_fastapi_handler
from genkit.plugins.google_genai import GoogleAI

ai = Genkit(
    plugins=[GoogleAI()],
    model='googleai/gemini-flash-latest',
)


class SaleItem(BaseModel):
    name: str
    price: str


class GetIngredientsInput(BaseModel):
    day_type: Literal['weekday', 'weekend'] = Field(
        description='Whether to fetch weekday or weekend sale prices.',
    )


@ai.tool(
    name='get_ingredients_on_sale',
    description=(
        'Returns the ingredients on sale at the local grocery store, with prices. '
        'The sale set differs between weekdays and weekends.'
    ),
)
async def get_ingredients_on_sale(input: GetIngredientsInput) -> list[SaleItem]:
    if input.day_type == 'weekend':
        return [
            SaleItem(name='chicken breast', price='$2.99/lb'),
            SaleItem(name='pasta', price='$0.79'),
            SaleItem(name='canned tomatoes', price='$0.99'),
            SaleItem(name='garlic', price='$0.50 / head'),
            SaleItem(name='olive oil', price='$6.99'),
        ]
    return [
        SaleItem(name='eggs', price='$3.49 / dozen'),
        SaleItem(name='spinach', price='$1.99'),
        SaleItem(name='parmesan', price='$4.99'),
        SaleItem(name='lemons', price='$0.50 each'),
        SaleItem(name='rice', price='$2.49'),
        SaleItem(name='butter', price='$3.99'),
    ]


class RecipeIngredient(BaseModel):
    name: str
    quantity: str
    on_sale: bool


class Recipe(BaseModel):
    title: str
    description: str
    servings: int
    ingredients: list[RecipeIngredient]
    steps: list[str]


class BargainChefInput(BaseModel):
    craving: str = Field(description='What the user feels like eating right now.')


@ai.flow(name='bargainChefFlow', chunk_type=Recipe)
async def bargain_chef_flow(input: BargainChefInput, ctx: ActionRunContext) -> Recipe:
    today = datetime.now().strftime('%A')

    stream_response = ai.generate_stream(
        prompt=(
            f'Today is {today}. The user is craving: {input.craving}.\n\n'
            'Call the get_ingredients_on_sale tool with the day_type that matches today. '
            'Saturday and Sunday are weekends; all other days are weekdays. '
            'Then propose ONE recipe that takes advantage of those deals. For each '
            "ingredient, set on_sale=true if it appears in the tool's response, "
            'false otherwise.'
        ),
        tools=[get_ingredients_on_sale],
        output_schema=Recipe,
        config={'temperature': 0.7, 'thinkingConfig': {'thinkingLevel': 'MINIMAL'}},
    )

    async for chunk in stream_response.stream:
        if chunk.output:
            ctx.send_chunk(chunk.output)

    response = await stream_response.response
    if not response.output:
        raise ValueError('Failed to generate recipe')
    return response.output


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)


@app.post('/bargainChefFlow', response_model=None)
@genkit_fastapi_handler(ai)
async def bargain_chef_endpoint():
    return bargain_chef_flow
