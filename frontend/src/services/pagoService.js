import api from './api';

export const obtenerPagos = async () => {
    const res = await api.get('pagos/');
    return res.data;
};
export const crearPago = async (data) => {
    const res = await api.post('pagos/', data);
    return res.data;
};
export const actualizarPago = async (id, data) => {
    const res = await api.put(`pagos/${id}/`, data);
    return res.data;
};
export const eliminarPago = async (id) => {
    await api.delete(`pagos/${id}/`);
};
