from django.contrib import admin
from .models import Categoria


@admin.register(Categoria)
class CategoriaAdmin(admin.ModelAdmin):
    list_display  = ('id', 'nombre_cat', 'estado_cat')
    list_filter   = ('estado_cat',)
    search_fields = ('nombre_cat',)
    ordering      = ('-id',)
