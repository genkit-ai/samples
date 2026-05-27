from datetime import datetime
from typing import Literal

from flask import Flask
from flask_cors import CORS
from pydantic import BaseModel, Field

from genkit import ActionRunContext, Genkit
from genkit.plugins.flask import genkit_flask_handler
from genkit.plugins.google_genai import GoogleAI

ai = Genkit(
    plugins=[GoogleAI()],
    model='googleai/gemini-flash-latest',
)

app = Flask(__name__)
CORS(app)


class SaleIngredient(BaseModel):
    name: str
    price: str


class GetIngredientsInput(BaseModel):
    day_type: Literal['weekday', 'weekend'] = Field(
        description='Whether to fetch weekday or weekend sale prices.',
    )


@ai.tool()
async def get_ingredients_on_sale(input: GetIngredientsInput) -> list[SaleIngredient]:
    """Returns the ingredients on sale at the local grocery store, with prices.
    The sale set differs between weekdays and weekends.
    """
    if input.day_type == 'weekend':
        return [
            SaleIngredient(name='chicken breast', price='$2.99/lb'),
            SaleIngredient(name='pasta', price='$0.79'),
            SaleIngredient(name='canned tomatoes', price='$0.99'),
            SaleIngredient(name='garlic', price='$0.50 / head'),
            SaleIngredient(name='olive oil', price='$6.99'),
        ]
    return [
        SaleIngredient(name='eggs', price='$3.49 / dozen'),
        SaleIngredient(name='spinach', price='$1.99'),
        SaleIngredient(name='parmesan', price='$4.99'),
        SaleIngredient(name='lemons', price='$0.50 each'),
        SaleIngredient(name='rice', price='$2.49'),
        SaleIngredient(name='butter', price='$3.99'),
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


@app.post('/bargainChefFlow')
@genkit_flask_handler(ai)
@ai.flow()
async def bargain_chef_flow(input: BargainChefInput, ctx: ActionRunContext) -> Recipe:
    today = datetime.now().strftime('%A')

    stream_response = ai.generate_stream(
        prompt=(
            f'Today is {today}. The user is craving: {input.craving}.\n\n'
            'Call the get_ingredients_on_sale tool with the day_type that matches '
            'today. Saturday and Sunday are weekends; all other days are weekdays. '
            'Then propose ONE recipe that takes advantage of those deals. For each '
            "ingredient, set on_sale=true if it appears in the tool's response, "
            'false otherwise.'
        ),
        tools=['get_ingredients_on_sale'],
        output_schema=Recipe,
        config={'temperature': 0.7},
    )

    async for chunk in stream_response.stream:
        if chunk.output:
            ctx.send_chunk(chunk.output)

    response = await stream_response.response
    if not response.output:
        raise ValueError('Failed to generate recipe')
    return response.output


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
