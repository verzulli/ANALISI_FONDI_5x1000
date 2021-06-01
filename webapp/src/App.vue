<template>
  <div id="app">
    <b-container fluid class="d-print-none text-center mt-1 mb-1">
      <b-navbar hover toggleable="md" type="dark" variant="info" class="rounded">
        <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
        <b-navbar-brand to="/">
          HOME
        </b-navbar-brand>
        <b-collapse is-nav id="nav_collapse">
          <b-navbar-nav class="ml-auto">
            <div>5 x 1000 - Grapher - v. 0.1pre-alfa - 01/06/2021</div> .
          </b-navbar-nav>
        </b-collapse>
      </b-navbar>
    </b-container>
    <b-container fluid>
      <router-view />
      <vue-snotify></vue-snotify>
    </b-container>
  </div>
</template>
