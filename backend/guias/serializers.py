from rest_framework import serializers
from .models import GuiaTuristico

class GuiaTuristicoSerializer(serializers.ModelSerializer):
    nombre_destino = serializers.ReadOnlyField(source='destino.nombre_destino')

    class Meta:
        model = GuiaTuristico
        fields = '__all__'
