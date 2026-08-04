// Crear un servicio para manejar las operaciones CRUD de clientes, utilizando la API RESTful del backend.
import api from './api';

// Listar todos los clientes.
export const obtenerClientes = async () => {
    const res = await api.get('clientes/clientes/');
    return res.data;
};

// Crear un nuevo cliente
export const crearCliente = async (data) => {
    const res = await api.post('clientes/clientes/', data);
    return res.data;
};

// Actualizar cliente existente
export const actualizarCliente = async (id, data) => {
    const res = await api.put(`clientes/clientes/${id}/`, data);
    return res.data;
};

// Eliminar cliente
export const eliminarCliente = async (id) => {
    await api.delete(`clientes/clientes/${id}/`);
};
