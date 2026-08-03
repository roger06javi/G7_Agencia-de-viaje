from rest_framework import serializers
from .models import PaqueteTuristico
from destinos.serializers import DestinoSerializer

class PaqueteTuristicoSerializer(serializers.ModelSerializer):
    nombre_destino = serializers.ReadOnlyField(source='destino.nombre_destino')

    class Meta:
        model = PaqueteTuristico
        fields = '__all__'
