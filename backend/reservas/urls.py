# Crear urls para el modelo de reserva, con rutas para listar, crear, actualizar y eliminar reservas.
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReservaViewSet

router = DefaultRouter()
router.register(r'', ReservaViewSet, basename='reserva')

urlpatterns = [
    path('', include(router.urls)),
]
