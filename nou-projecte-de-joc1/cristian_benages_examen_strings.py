#1. Escriviu un programa (pot ser o no una funció, com vulgueu) que imprimeixi una paraula al revés, de la manera que vulgueu.
paraula = "hola"
linia = ""

for i in range(len(paraula) - 1, -1, -1):
    linia = linia + paraula[i]
print(linia)
#4. Feu una funció que ens digui si unes sigles corresponen a un nom. La funció tindrà la següent notació: comprova_sigles(sigles, nom) i retornarà un booleà.
def comprova_sigles(sigles,nom):
    nom = nom.split(" ")
    linia = ""
    for p in nom:
        linia = linia + p[0]
    if linia == sigles:
        return True
    else:
        return False
print(comprova_sigles("PSC","Pedro Santos Conejo"))
#5. Feu una funció que ens digui si dues paraules són ANAGRAMES. Dues paraules són anagrames si contenen les mateixes lletres, però en ordre diferent.
def es_anagrama(paraula1,paraula2):
    paraula3 = paraula1 + paraula2
    i = 0
    j = len(paraula3) - 1
    while i < j and paraula3[i] == paraula3[j]: 
        i = i + 1
        j = j - 1
    if i < j:
        return False
    else:
        return True
print(es_anagrama("roma","amor"))
