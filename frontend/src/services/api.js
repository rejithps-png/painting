import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Clear local storage and redirect to login
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  register: (userData) => api.post('/auth/register', userData),
  login: (credentials) => api.post('/auth/login', credentials),
  checkMobile: (mobile) => api.get(`/auth/check-mobile/${mobile}`),
};

// Admin API
export const adminAPI = {
  login: (credentials) => api.post('/admin/login', credentials),
  getDashboardStats: () => api.get('/admin/dashboard-stats'),
  getPaintings: () => api.get('/admin/paintings'),
  createPainting: (paintingData) => api.post('/admin/paintings', paintingData),
  updatePainting: (id, paintingData) => api.put(`/admin/paintings/${id}`, paintingData),
  deletePainting: (id) => api.delete(`/admin/paintings/${id}`),
  getQRCode: (id) => api.get(`/admin/paintings/${id}/qrcode`),
  getBids: () => api.get('/admin/bids'),
  getAuctionSettings: () => api.get('/admin/auction-settings'),
  updateAuctionSettings: (settings) => api.put('/admin/auction-settings', settings),
};

// Painting API
export const paintingAPI = {
  getAllPaintings: () => api.get('/paintings'),
  getPainting: (id) => api.get(`/paintings/${id}`),
  placeBid: (bidData) => api.post('/paintings/bid', bidData),
  getUserBids: (mobile) => api.get(`/paintings/user-bids?mobile=${mobile}`),
};

export default api;
