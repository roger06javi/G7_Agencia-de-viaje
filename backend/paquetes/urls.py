from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PaqueteTuristicoViewSet

router = DefaultRouter()
router.register(r'', PaqueteTuristicoViewSet, basename='paquete')

urlpatterns = [
    path('', include(router.urls)),
]
