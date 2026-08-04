from django.test import TestCase
from rest_framework.test import APIClient


class ClienteAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_list_and_create_clientes_without_auth(self):
        response = self.client.get('/api/clientes/clientes/')
        self.assertEqual(response.status_code, 200)

        response = self.client.post('/api/clientes/clientes/', {
            'nombre': 'Ana',
            'apellido': 'Pérez',
            'cedula': '12345678',
            'telefono': '3001234567',
            'correo': 'ana@example.com',
        }, format='json')

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['nombre'], 'Ana')
