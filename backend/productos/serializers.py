from rest_framework import serializers
from .models import Producto


class ProductoSerializer(serializers.ModelSerializer):
    categoria_nombre = serializers.CharField(source='categoria.nombre_cat', read_only=True)

    class Meta:
        model = Producto
        fields = ['id', 'nombre_prod', 'descripcion_prod', 'precio', 'stock', 'estado_prod', 'categoria', 'categoria_nombre']