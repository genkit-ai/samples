from django.urls import path
from recipes.views import bargain_chef_flow

urlpatterns = [
    path('bargainChefFlow', bargain_chef_flow),
]
