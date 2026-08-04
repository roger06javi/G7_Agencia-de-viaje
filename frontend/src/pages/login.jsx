import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

function Login() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [errorMsg, setErrorMsg] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        const token = localStorage.getItem('access');
        if (token) {
            navigate('/dashboard');
        }
    }, [navigate]);

    const iniciarSesion = async (e) => {
        e.preventDefault();
        setErrorMsg('');
        setIsLoading(true);

        try {
            const respuesta = await api.post('login/', { 
                username, 
                password 
            });

            localStorage.setItem('access', respuesta.data.access);
            localStorage.setItem('refresh', respuesta.data.refresh);
            localStorage.setItem('username', username);

            console.log('Login exitoso:', respuesta.data);
            navigate('/dashboard');
        } catch (error) {
            console.error('Error al iniciar sesión:', error);
            const detalle = error.response?.data?.detail;
            if (detalle) {
                if (detalle === 'No active account found with the given credentials') {
                    setErrorMsg('No se encontró una cuenta activa con las credenciales proporcionadas.'); // Mensaje de error más amigable para el usuario.
                } else {
                    setErrorMsg(detalle);
                }
            } else {
                setErrorMsg('Usuario o contraseña incorrectos. Intente nuevamente.');
            }
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="login-container">   
            <div className="login-card">
                <div className="login-header">
                    <div className="avatar-icon">�</div>
                    <h2>Iniciar Sesión</h2>
                    <p>Ingrese sus credenciales para acceder a la plataforma</p>
                </div>

                {errorMsg && <div className="error-banner">{errorMsg}</div>}

                <form onSubmit={iniciarSesion} className="login-form">
                    <div className="input-group">
                        <label htmlFor="username">Usuario</label>
                        <input 
                            id="username"
                            type="text" 
                            placeholder="Ingrese su usuario" 
                            value={username} 
                            onChange={(e) => setUsername(e.target.value)}
                            required
                        />
                    </div>

                    <div className="input-group">
                        <label htmlFor="password">Contraseña</label>
                        <input 
                            id="password"
                            type="password" 
                            placeholder="Ingrese su contraseña" 
                            value={password} 
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    <button type="submit" className="btn-primary" disabled={isLoading}>
                        {isLoading ? 'Iniciando sesión...' : '🔑 Iniciar Sesión'} // Ubicar señales amigables para el sistema en el login. jsx
                    </button>
                </form>
            </div>
        </div>
    );
}

export default Login;