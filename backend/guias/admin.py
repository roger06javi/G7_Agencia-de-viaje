from django.contrib import admin
from .models import GuiaTuristico

@admin.register(GuiaTuristico)
class GuiaTuristicoAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombre', 'telefono', 'experiencia', 'destino')
