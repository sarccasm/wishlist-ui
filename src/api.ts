import axios, { type InternalAxiosRequestConfig } from 'axios'
import { useAuthStore } from './store/auth'

declare global {
  interface Window {
    __WISHLIST_CONFIG__?: {
      apiBase?: string
    }
  }
}

const API_BASE =
  window.__WISHLIST_CONFIG__?.apiBase ||
  import.meta.env.VITE_API_BASE ||
  'http://localhost:8000'

const api = axios.create({
  baseURL: API_BASE,
})

api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

export default api
