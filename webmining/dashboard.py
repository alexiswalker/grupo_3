import streamlit as st
import pandas as pd

companies = pd.read_csv('clutch_ar_companies_cluster.csv')

st.title("Clutch web mining")

with st.sidebar:
    with st.form("Filtros"):
        st.selectbox("Empresa", companies.company_name, key="empresa")
        st.form_submit_button("Aplicar")

st.markdown(f"{st.session_state.empresa}")

empresa = companies.query(f"company_name == '{st.session_state.empresa}'")
empresas_mismo_cluster = companies.query(f"cluster == {empresa.cluster.values[0]}")

st.markdown(f"Cluster: {empresa.cluster.values[0]}")
st.dataframe(empresas_mismo_cluster)