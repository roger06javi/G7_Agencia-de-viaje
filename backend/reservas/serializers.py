# Crear serializer para el modelo de reserva, con campos de fecha, cantidad de personas, estado, cliente y paquete turístico.
from rest_framework import serializers
from .models import Reserva
# Creamos el serializer para el modelo de reserva
class ReservaSerializer(serializers.ModelSerializer):
    nombre_cliente = serializers.ReadOnlyField(source='cliente.nombre')
    apellido_cliente = serializers.ReadOnlyField(source='cliente.apellido')
    nombre_paquete = serializers.ReadOnlyField(source='paquete.nombre_paquete')

    class Meta:
        model = Reserva
        fields = '__all__'
