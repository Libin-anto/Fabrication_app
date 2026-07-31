import axios from 'axios';

// Use the environment variable if available, otherwise fallback to local IP
export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'http://192.168.137.1:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add a request interceptor to inject the Tenant ID for multi-tenancy
api.interceptors.request.use((config) => {
  // In a real app, you would fetch this from AsyncStorage or state management
  const tenantId = 'default_tenant'; 
  config.headers['X-Tenant-ID'] = tenantId;
  return config;
}, (error) => {
  return Promise.reject(error);
});

export const getAvailableMachines = async () => {
  const response = await api.get('/machines/?status=Available');
  return response.data;
};

export const getDashboardStats = async () => {
  const response = await api.get('/dashboard/stats');
  return response.data;
};

export const getMachines = async () => {
  const response = await api.get('/machines/');
  return response.data;
};

export const createMachine = async (data: any) => {
  const response = await api.post('/machines/', data);
  return response.data;
};

export const updateMachine = async (id: number, data: any) => {
  const response = await api.put(`/machines/${id}`, data);
  return response.data;
};

export const deleteMachine = async (id: number) => {
  const response = await api.delete(`/machines/${id}`);
  return response.data;
};

export const getWorkers = async () => {
  const response = await api.get('/workers/');
  return response.data;
};

export const createWorker = async (data: any) => {
  const response = await api.post('/workers/', data);
  return response.data;
};

export const updateWorker = async (id: number, data: any) => {
  const response = await api.put(`/workers/${id}`, data);
  return response.data;
};

export const deleteWorker = async (id: number) => {
  const response = await api.delete(`/workers/${id}`);
  return response.data;
};

export const assignMachine = async (workerId: number, machineId: number, location: string = 'On Site') => {
  const response = await api.post('/assignments/assign', {
    worker_id: workerId,
    machine_id: machineId,
    location: location,
  });
  return response.data;
};

export const getCurrentAssignments = async () => {
  const response = await api.get('/assignments/current');
  return response.data;
};

export const getAssignmentHistory = async () => {
  const response = await api.get('/assignments/history');
  return response.data;
};

export const returnAssignment = async (assignmentId: number) => {
  const response = await api.post(`/assignments/${assignmentId}/return`);
  return response.data;
};

export const updateAssignmentLocation = async (assignmentId: number, location: string) => {
  const response = await api.patch(`/assignments/${assignmentId}/location`, { location });
  return response.data;
};

export const searchGlobal = async (query: string) => {
  const response = await api.get(`/search/?q=${encodeURIComponent(query)}`);
  return response.data;
};
