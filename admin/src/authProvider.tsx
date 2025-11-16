import type { AuthProvider } from 'react-admin'

const API = import.meta.env.VITE_API_URL!.replace(/\/$/, '')

export const authProvider: AuthProvider = {
  // called when the user submits the login form
  login: async ({ username, password }) => {
    console.log('[auth] login →', username)

    const res = await fetch(`${API}/session`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user: { email: username, password } }),
    })

    console.log('[auth] login status', res.status)

    if (!res.ok) {
      const text = await res.text().catch(() => '')
      console.error('[auth] login failed body:', text)
      throw new Error('Login failed')
    }

    const token = res.headers.get('authorization')

    console.log('[auth] login token?', token)

    const { user } = await res.json().catch((e) => {
      console.error('[auth] login json parse error', e)
      throw e
    })

    console.log('[auth] login user', user, 'token?', !!token)

    if (!token) throw new Error('Missing token in response')

    // if you REQUIRE admin to access RA UI, keep this check:
    if (!user?.admin) {
      console.error('[auth] user is not admin, denying access')
      throw new Error('Not authorized')
    }

    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(user))

    console.log('[auth] login success, token saved')
    return Promise.resolve()
  },

  logout: () => {
    console.log('[auth] logout')
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    return Promise.resolve()
  },

  checkAuth: () => {
    const token = localStorage.getItem('token')
    console.log('[auth] checkAuth, token?', !!token)
    return token ? Promise.resolve() : Promise.reject()
  },

  // ONLY log the error for now, don't kick the user out
  checkError: (error: any) => {
    console.log('[auth] checkError', error)
    // if you later want to log out on 401/403 you can re-enable:
    // if (error?.status === 401 || error?.status === 403) {
    //   localStorage.removeItem('token')
    //   localStorage.removeItem('user')
    //   return Promise.reject()
    // }
    return Promise.resolve()
  },

  getPermissions: () => {
    const raw = localStorage.getItem('user')
    let user: any = null
    try {
      user = raw ? JSON.parse(raw) : null
    } catch (e) {
      console.error('[auth] getPermissions JSON parse error', e)
    }
    console.log('[auth] getPermissions', user?.admin)
    return Promise.resolve(user?.admin ? ['admin'] : [])
  },
}
