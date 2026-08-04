# CREAR RUTAS DE PRODUCTO, CON VISTA DE PRODUCTO Y SERIALIZADOR DE PRODUCTO.
from rest_framework import routers
from django.urls import path, include
from .models import Producto
from .views import ProductoViewSet
from .serializers import ProductoSerializer

router = routers.DefaultRouter()
router.register(r'productos', ProductoViewSet, basename='productos')

urlpatterns = [
    path('', include(router.urls)),
]