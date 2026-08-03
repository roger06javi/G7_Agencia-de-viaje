import api from './api';

export const obtenerReservas = async () => {
    const res = await api.get('reservas/');
    return res.data;
};
export const crearReserva = async (data) => {
    const res = await api.post('reservas/', data);
    return res.data;
};
export const actualizarReserva = async (id, data) => {
    const res = await api.put(`reservas/${id}/`, data);
    return res.data;
};
export const eliminarReserva = async (id) => {
    await api.delete(`reservas/${id}/`);
};
