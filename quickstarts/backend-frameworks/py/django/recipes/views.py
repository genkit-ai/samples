import json
from datetime import datetime
from typing import Literal

from django.http import StreamingHttpResponse
from ninja import NinjaAPI, Schema
from pydantic import BaseModel, Field

from genkit import ActionRunContext, Genkit
from genkit.plugins.google_genai import GoogleAI

ai = Genkit(plugins=[GoogleAI()])


class IngredientOnSale(BaseModel):
    name: str
    price: str


class GetIngredientsInput(BaseModel):
    day_type: Literal['weekday', 'weekend'] = Field(
        description='Whether to fetch weekday or weekend sale prices.'
    )


@ai.tool(
    name='get_ingredients_on_sale',
    description=(
        'Returns the ingredients on sale at the local grocery store, with prices. '
        'The sale set differs between weekdays and weekends.'
    ),
)
async def get_ingredients_on_sale(
    input: GetIngredientsInput,
) -> list[IngredientOnSale]:
    if input.day_type == 'weekend':
        return [
            IngredientOnSale(name='chicken breast', price='$2.99/lb'),
            IngredientOnSale(name='pasta', price='$0.79'),
            IngredientOnSale(name='canned tomatoes', price='$0.99'),
            IngredientOnSale(name='garlic', price='$0.50 / head'),
            IngredientOnSale(name='olive oil', price='$6.99'),
        ]
    return [
        IngredientOnSale(name='eggs', price='$3.49 / dozen'),
        IngredientOnSale(name='spinach', price='$1.99'),
        IngredientOnSale(name='parmesan', price='$4.99'),
        IngredientOnSale(name='lemons', price='$0.50 each'),
        IngredientOnSale(name='rice', price='$2.49'),
        IngredientOnSale(name='butter', price='$3.99'),
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
async def bargain_chef_flow(
    input: BargainChefInput,
    ctx: ActionRunContext,
) -> Recipe:
    today = datetime.now().strftime('%A')

    stream_response = ai.generate_stream(
        model='googleai/gemini-flash-latest',
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


api = NinjaAPI()


class GenkitRequest(Schema):
    data: BargainChefInput


@api.post('/bargainChefFlow')
async def bargain_chef_endpoint(request, payload: GenkitRequest):
    if request.headers.get('Accept') == 'text/event-stream':
        async def event_stream():
            stream_response = bargain_chef_flow.stream(payload.data)
            async for chunk in stream_response.stream:
                yield f'data: {json.dumps({"message": chunk.model_dump()})}\n\n'
            result = await stream_response.response
            yield f'data: {json.dumps({"result": result.model_dump()})}\n\n'

        return StreamingHttpResponse(event_stream(), content_type='text/event-stream')

    result = await bargain_chef_flow(payload.data)
    return {'result': result.model_dump()}
