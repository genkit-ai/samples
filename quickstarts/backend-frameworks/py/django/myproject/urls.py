from django.urls import path
from recipes.views import api

urlpatterns = [
    path('', api.urls),
]
