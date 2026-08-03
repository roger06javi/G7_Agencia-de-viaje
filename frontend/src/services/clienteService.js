import api from './api';

export const obtenerClientes = async () => {
    const res = await api.get('clientes/clientes/');
    return res.data;
};
export const crearCliente = async (data) => {
    const res = await api.post('clientes/clientes/', data);
    return res.data;
};
export const actualizarCliente = async (id, data) => {
    const res = await api.put(`clientes/clientes/${id}/`, data);
    return res.data;
};
export const eliminarCliente = async (id) => {
    await api.delete(`clientes/clientes/${id}/`);
};
