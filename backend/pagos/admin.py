from django.contrib import admin
from .models import Pago

@admin.register(Pago)
class PagoAdmin(admin.ModelAdmin):
    list_display = ('id', 'fecha_pago', 'monto', 'metodo_pago', 'reserva')
