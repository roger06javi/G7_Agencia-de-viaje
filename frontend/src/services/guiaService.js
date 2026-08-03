import api from './api';

export const obtenerGuias = async () => {
    const res = await api.get('guias/');
    return res.data;
};
export const crearGuia = async (data) => {
    const res = await api.post('guias/', data);
    return res.data;
};
export const actualizarGuia = async (id, data) => {
    const res = await api.put(`guias/${id}/`, data);
    return res.data;
};
export const eliminarGuia = async (id) => {
    await api.delete(`guias/${id}/`);
};
