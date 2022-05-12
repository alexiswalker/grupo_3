import streamlit as st
import pandas as pd
import plotly.express as px
from sklearn.decomposition import PCA
st.set_page_config(layout="wide")

companies = pd.read_csv('clutch_ar_companies_cluster.csv')
columnas_client_focus = ["company_name", "client_focus_enterprise_1b", "client_focus_midmarket_10m_1b", "client_focus_small_business"]
companies["client_focus_sum"] = companies.client_focus_enterprise_1b + companies.client_focus_midmarket_10m_1b + companies.client_focus_small_business
companies_client_focus = companies.query("client_focus_sum > 0")
empresas_con_datos = companies.query("client_focus_sum > 0 & rating != 0")

with st.sidebar:
    with st.form("Filtros"):
        st.selectbox("Empresa", empresas_con_datos.company_name.sort_values(), key="empresa")
        st.form_submit_button("Aplicar")

st.title(f"Empresa a comparar: {st.session_state.empresa}")
st.markdown("""
    Comparamos empresas similares de IT con la empresa seleccionada.
""")

empresa = companies.query(f"company_name == '{st.session_state.empresa}'")
empresas_mismo_cluster = companies.query(f"cluster == {empresa.cluster.values[0]}")

col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Cluster", empresa.cluster.values[0])
with col2:
    st.metric("# Empresas", empresas_mismo_cluster.shape[0])
with col3:
    st.metric("Score Promedio", f"{empresas_mismo_cluster.query('rating != 0').rating.mean():.2f}")

col1, col2 = st.columns(2)
with col1:
    # grafico de reviews vs rating
    empresas_del_cluster_con_rating = empresas_mismo_cluster.query("rating != 0")
    empresas_del_cluster_con_rating["referencia"] = "competencia"
    empresas_del_cluster_con_rating.loc[empresa.index, ["referencia"]] = "nosotros"
    empresas_del_cluster_con_rating = empresas_del_cluster_con_rating.sort_values(["referencia"], ascending=True)
    fig = px.scatter(empresas_del_cluster_con_rating,
                    x="reviews",
                    y="rating", 
                    color="referencia", 
                    size="employees",
                    hover_name="company_name")
    fig.update_layout(title='Rating, reviews y empleados',
                      showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

with col2:
    # otro grafico
    pca = PCA(n_components=2)
    x = companies_client_focus[columnas_client_focus].drop(columns=["company_name"])
    x = pca.fit_transform(x)
    companies_client_focus_pca = pd.DataFrame(x)
    companies_client_focus_pca.columns = ["0", "1"]
    companies_client_focus_pca.index = companies_client_focus.index
    companies_client_focus_pca["company_name"] = companies_client_focus["company_name"]
    companies_client_focus_pca["employees"] = companies_client_focus["employees"]
    companies_client_focus_pca["enterprise"] = companies_client_focus["client_focus_enterprise_1b"].astype(str) + "%"
    companies_client_focus_pca["midmarket"] = companies_client_focus["client_focus_midmarket_10m_1b"].astype(str) + "%"
    companies_client_focus_pca["small_business"] = companies_client_focus["client_focus_small_business"].astype(str) + "%"
    companies_client_focus_pca["referencia"] = "competencia"
    companies_client_focus_pca.loc[empresa.index, ["referencia"]] = "nosotros"
    companies_client_focus_pca = companies_client_focus_pca.sort_values(["referencia"], ascending=True)
    fig = px.scatter(companies_client_focus_pca,
                    x="0",
                    y="1", 
                    color="referencia",
                    size="employees",
                    hover_name="company_name",
                    hover_data=["enterprise", "midmarket", "small_business"])
    fig.update_layout(title='Client focus y empleados',
                      xaxis_title="",
                      yaxis_title="",
                      showlegend=False)
    st.plotly_chart(fig, use_container_width=True)
