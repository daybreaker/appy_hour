import React from 'react'
import ReactDOM from 'react-dom/client'
import { Admin, Resource, ListGuesser } from 'react-admin'
import { dataProvider } from './dataProvider'
import { authProvider } from './authProvider'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Admin dataProvider={dataProvider} authProvider={authProvider} requireAuth>
      <Resource name="venues" list={ListGuesser} />
    </Admin>
  </React.StrictMode>
)
