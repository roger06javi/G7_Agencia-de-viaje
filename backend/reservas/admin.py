from django.contrib import admin
from .models import Reserva

@admin.register(Reserva)
class ReservaAdmin(admin.ModelAdmin):
    list_display = ('id', 'fecha_reserva', 'cantidad_personas', 'estado', 'cliente', 'paquete')
