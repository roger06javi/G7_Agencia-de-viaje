from rest_framework import serializers
from .models import Reserva

class ReservaSerializer(serializers.ModelSerializer):
    nombre_cliente = serializers.ReadOnlyField(source='cliente.nombre')
    apellido_cliente = serializers.ReadOnlyField(source='cliente.apellido')
    nombre_paquete = serializers.ReadOnlyField(source='paquete.nombre_paquete')

    class Meta:
        model = Reserva
        fields = '__all__'
