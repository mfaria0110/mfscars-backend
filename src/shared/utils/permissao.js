function isMaster(user){
  return user.master === true && user.tipo === "admin"
}

function aplicarFiltroEmpresa(query, user){

  if(!isMaster(user)){
    query.where("empresa_id", user.empresa_id)
  }

  return query
}

module.exports = {
  isMaster,
  aplicarFiltroEmpresa
}