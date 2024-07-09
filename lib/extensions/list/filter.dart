
/*We create a filter for our stream in order 
to check if all notes corresponds to the current user. */
extension Filter<T> on Stream<List<T>>{
  Stream<List<T>> filter(bool Function(T) where) =>
    map((items) => items.where(where).toList()); 
    //tratamos con una "lista de listas" de ahí el codigo complejo.
}