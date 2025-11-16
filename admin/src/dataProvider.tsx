import simpleRestProvider from 'ra-data-simple-rest'
import { fetchUtils } from 'ra-core'

const API = import.meta.env.VITE_API_URL!.replace(/\/$/, '')

const httpClient = (url: string, options: any = {}) => {
  const token = localStorage.getItem('token')
  console.log('[http] request', url, 'token?', token)

  options.headers = new Headers(options.headers || { Accept: 'application/json' })
  if (token) options.headers.set('Authorization', token)

  return fetchUtils.fetchJson(url, options).catch((err) => {
    console.error('[http] fetchJson error', err)
    throw err
  })
}

export const dataProvider = simpleRestProvider(API, httpClient)
