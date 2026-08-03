import api from './api';

export const obtenerDestinos = async () => {
    const res = await api.get('destinos/');
    return res.data;
};
export const crearDestino = async (data) => {
    const res = await api.post('destinos/', data);
    return res.data;
};
export const actualizarDestino = async (id, data) => {
    const res = await api.put(`destinos/${id}/`, data);
    return res.data;
};
export const eliminarDestino = async (id) => {
    await api.delete(`destinos/${id}/`);
};
