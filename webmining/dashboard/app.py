import streamlit as st
import pandas as pd
import plotly.express as px
from sklearn.decomposition import PCA

st.set_page_config(layout="wide")

empresas = pd.read_csv("../data/02 - processed/companies_processed.csv")
columnas_client_focus = [
    col for col in empresas.columns if col.startswith("client_focus")
]

empresas["client_focus_sum"] = (
    empresas.client_focus_enterprise_1b
    + empresas.client_focus_midmarket_10m_1b
    + empresas.client_focus_small_business
)
empresas_con_datos = empresas.query("client_focus_sum > 0 & rating != 0")

with st.sidebar:
    with st.form("Filtros"):
        st.selectbox(
            "Empresa", empresas_con_datos.company_name.sort_values(), key="empresa"
        )
        st.form_submit_button("Aplicar")

st.title(f"Empresa a comparar: {st.session_state.empresa}")
st.markdown(
    """
    Comparamos empresas similares de IT con la empresa seleccionada.
"""
)

empresa = empresas.query(f"company_name == '{st.session_state.empresa}'")
empresas_mismo_cluster = empresas.query(f"cluster == {empresa.cluster.values[0]}")

col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Cluster", empresa.cluster.values[0])
with col2:
    st.metric("# Empresas", empresas_mismo_cluster.shape[0])
with col3:
    st.metric(
        "Score Promedio",
        f"{empresas_mismo_cluster.query('rating != 0').rating.mean():.2f}",
    )

col1, col2 = st.columns(2)
with col1:
    # grafico de reviews vs rating
    empresas_del_cluster_con_rating = empresas_mismo_cluster.query("rating != 0")
    empresas_del_cluster_con_rating["referencia"] = "competencia"
    empresas_del_cluster_con_rating.loc[empresa.index, ["referencia"]] = "nosotros"
    empresas_del_cluster_con_rating = empresas_del_cluster_con_rating.sort_values(
        ["referencia"], ascending=True
    )
    fig = px.scatter(
        empresas_del_cluster_con_rating,
        x="reviews",
        y="rating",
        color="referencia",
        size="employees",
        hover_name="company_name",
    )
    fig.update_layout(title="Rating, reviews y empleados", showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

with col2:
    # otro grafico
    pca = PCA(n_components=2)
    x = empresas_con_datos[columnas_client_focus]
    x = pca.fit_transform(x)
    companies_client_focus_pca = pd.DataFrame(x)
    companies_client_focus_pca.columns = ["0", "1"]
    companies_client_focus_pca.index = empresas_con_datos.index
    companies_client_focus_pca["company_name"] = empresas_con_datos["company_name"]
    companies_client_focus_pca["employees"] = empresas_con_datos["employees"]
    companies_client_focus_pca["enterprise"] = (
        empresas_con_datos["client_focus_enterprise_1b"].astype(str) + "%"
    )
    companies_client_focus_pca["midmarket"] = (
        empresas_con_datos["client_focus_midmarket_10m_1b"].astype(str) + "%"
    )
    companies_client_focus_pca["small_business"] = (
        empresas_con_datos["client_focus_small_business"].astype(str) + "%"
    )
    companies_client_focus_pca["referencia"] = "competencia"
    companies_client_focus_pca.loc[empresa.index, ["referencia"]] = "nosotros"
    companies_client_focus_pca = companies_client_focus_pca.sort_values(
        ["referencia"], ascending=True
    )
    fig = px.scatter(
        companies_client_focus_pca,
        x="0",
        y="1",
        color="referencia",
        size="employees",
        hover_name="company_name",
        hover_data=["enterprise", "midmarket", "small_business"],
    )
    fig.update_layout(
        title="Client focus y empleados",
        xaxis_title="",
        yaxis_title="",
        showlegend=False,
    )
    st.plotly_chart(fig, use_container_width=True)
