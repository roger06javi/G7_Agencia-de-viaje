from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GuiaTuristicoViewSet

router = DefaultRouter()
router.register(r'', GuiaTuristicoViewSet, basename='guia')

urlpatterns = [
    path('', include(router.urls)),
]
