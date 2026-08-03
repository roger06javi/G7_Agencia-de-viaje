from django.contrib import admin
from .models import PaqueteTuristico

@admin.register(PaqueteTuristico)
class PaqueteTuristicoAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombre_paquete', 'precio', 'duracion_dias', 'destino')
