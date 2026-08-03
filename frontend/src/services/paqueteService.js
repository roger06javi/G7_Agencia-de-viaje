import api from './api';

export const obtenerPaquetes = async () => {
    const res = await api.get('paquetes/');
    return res.data;
};
export const crearPaquete = async (data) => {
    const res = await api.post('paquetes/', data);
    return res.data;
};
export const actualizarPaquete = async (id, data) => {
    const res = await api.put(`paquetes/${id}/`, data);
    return res.data;
};
export const eliminarPaquete = async (id) => {
    await api.delete(`paquetes/${id}/`);
};
