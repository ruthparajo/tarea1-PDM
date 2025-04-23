import pandas as pd
import matplotlib.pyplot as plt

# Charger les données depuis le fichier Excel
file_path = 'consultas tarea1.xlsx'
data = pd.read_excel(file_path, sheet_name='consulta 1')

# Transformer la colonne 'mes' en année
data['año'] = pd.to_datetime(data['mes']).dt.year

# Utiliser un style graphique valide
plt.style.use('seaborn-v0_8-darkgrid')  # Style correct

# Parcourir chaque année pour créer un camembert
for year in data['año'].unique():
    # Filtrer les données pour l'année actuelle
    year_data = data[data['año'] == year]
    
    # Agréger les comptes par thème
    theme_proportions = year_data.groupby('palabra')['conteo'].sum().reset_index()

    # Calculer la proportion totale
    total_conteo = theme_proportions['conteo'].sum()
    theme_proportions['proporcion'] = theme_proportions['conteo'] / total_conteo

    # Séparer les thèmes importants (>5%) et "Otros"
    threshold = 0.02
    otros_data = theme_proportions[theme_proportions['proporcion'] < threshold]
    otros_conteo = otros_data['conteo'].sum()
    filtered_data = theme_proportions[theme_proportions['proporcion'] >= threshold]
    otros_row = pd.DataFrame({'palabra': ['Otros'], 'conteo': [otros_conteo]})
    filtered_data = pd.concat([filtered_data, otros_row], ignore_index=True)

    # Recalculer les proportions avec la catégorie "Otros"
    filtered_data['proporcion'] = filtered_data['conteo'] / total_conteo

    # Créer le graphique camembert
    plt.figure(figsize=(10, 8))
    plt.pie(
        filtered_data['proporcion'],
        labels=filtered_data['palabra'],
        autopct='%1.1f%%',
        startangle=90,
        colors=plt.cm.tab20.colors,
        pctdistance=0.85
    )
    
    # Ajouter un cercle au centre pour un effet "donut"
    centre_circle = plt.Circle((0, 0), 0.70, fc='white')
    fig = plt.gcf()
    fig.gca().add_artist(centre_circle)

    # Ajouter le titre en espagnol
    plt.title(f'Proporción de las temáticas tratadas en el Congreso en {year}', fontsize=14)
    
    # Ajuster la mise en page pour plus de clarté
    plt.tight_layout()
    
    # Afficher le graphique
    plt.show()
