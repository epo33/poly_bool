poly_bool

Opérations booléennes sur des polygones (union, intersection, ...)

## Crédit 
Basé sur le portage Dart fait par https://github.com/mohammedX6/poly_bool_dart/tree/master du code écrit par https://github.com/velipso/polybooljs.


## Utilisation

    final polyBool = PolyBool();
    final region1 = polyBool.region( [ /* Points */]);
    final combinaison = region1.combine( [ /* Points*/]);
    print( combinaison.union.polygon);
    print( combinaison.intersection.polygon);
    print( combinaison.difference.polygon);
    print( combinaison.inverseDifference.polygon);
    print( combinaison.xor.polygon);

## Notes
Tests unitaires à compléter


# Resources

Pour une explication détaillée de l'agorithme, voir https://sean.cm/a/polygon-clipping-pt2.