// Servicio para manejar las reservas en el frontend, utilizando la API del backend.
import api from './api';

// Obtener todas las reservas, incluyendo información del cliente y del paquete turístico
export const obtenerReservas = async () => {
    const res = await api.get('reservas/');
    return res.data;
};

// Crear una nueva reserva, incluyendo información del cliente y del paquete turístico
export const crearReserva = async (data) => {
    const res = await api.post('reservas/', data);
    return res.data;
};

// Actualizar una reserva existente, incluyendo información del cliente y del paquete turístico
export const actualizarReserva = async (id, data) => {
    const res = await api.put(`reservas/${id}/`, data);
    return res.data;
};

// Eliminar una reserva existente, incluyendo información del cliente y del paquete turístico
export const eliminarReserva = async (id) => {
    await api.delete(`reservas/${id}/`);
};
