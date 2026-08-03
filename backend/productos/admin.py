from django.contrib import admin
from .models import Producto


@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display  = ('id', 'nombre_prod', 'categoria', 'precio', 'stock', 'estado_prod')
    list_filter   = ('estado_prod', 'categoria')
    search_fields = ('nombre_prod',)
    ordering      = ('-id',)
    raw_id_fields = ('categoria',)
