# 💙 VivaBem+

> Aplicativo gamificado de assistência à rotina e saúde para idosos.

![Project Status](https://img.shields.io/badge/status-em_desenvolvimento-orange)
![Java](https://img.shields.io/badge/Java-21-red)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.5-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.0-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)

## 📖 Sobre o Projeto

O **VivaBem+** é uma solução móvel desenvolvida como Trabalho de Conclusão de Curso (TCC). O objetivo é auxiliar idosos no gerenciamento de suas rotinas diárias, promovendo autonomia e qualidade de vida através da gamificação.

O sistema oferece funcionalidades como lembretes de medicamentos, registro de atividades físicas, monitoramento nutricional e assistente virtual inteligente.

## ✨ Funcionalidades Principais

* **🔐 Autenticação Segura:** Login e cadastro com JWT (JSON Web Token).
* **💊 Gestão de Medicamentos:** Lembretes e controle de horários.
* **🧠 Atividades Cognitivas:** Exercícios para estímulo mental.
* **🤖 Assistente IA:** Integração com **Google Gemini** para gerar dicas de saúde personalizadas.
* **📧 Notificações:** Envio de alertas via E-mail (SMTP Gmail).
* **🏆 Gamificação:** Sistema de recompensas para incentivar o uso diário.

## 🛠️ Tecnologias Utilizadas

### Backend (API REST)
* **Linguagem:** Java 21
* **Framework:** Spring Boot 3.2.5
* **Segurança:** Spring Security 6 + JWT
* **Banco de Dados:** PostgreSQL
* **IA:** Integração com API do Google Gemini
* **Deploy:** Google Cloud Platform (VM Compute Engine + Systemd)

### Frontend (Mobile)
* **Framework:** Flutter
* **Conexão:** HTTP / Dio
* **Armazenamento Local:** Flutter Secure Storage

## 🏗️ Arquitetura e Deploy

O sistema foi implantado em uma instância **Linux (Debian)** no **Google Cloud Compute Engine**.
* O Backend roda como um serviço background do Linux (`systemd`).
* O Banco de Dados PostgreSQL está hospedado na mesma instância para otimização de custos/recursos.

## 🚀 Como executar o projeto

### Pré-requisitos
* Java 21 JDK
* Maven
* Flutter SDK
* PostgreSQL

### 1. Configuração do Backend

1. Clone o repositório:
   ```bash
   git clone [https://github.com/seu-usuario/seu-repo.git](https://github.com/seu-usuario/seu-repo.git)
2. Configure as variáveis de ambiente no arquivo application.properties ou nas variáveis do sistema:

- SPRING_DATASOURCE_URL

- SPRING_DATASOURCE_PASSWORD

- GEMINI_API_KEY

- SPRING_MAIL_PASSWORD
  
## 🤝 Autores

<table align="center">
  <tr>
      <a href="https://www.linkedin.com/in/gabriel-sousa-2795a9166/">
        <br>
        <b>Gabriel Sousa Correia</b>
      </a>
      <a href="https://www.linkedin.com/in/daniellukan/">
        <br>
        <b>Daniel Lukan Schimith Silva</b>
      </a>
</table>


* **Desenvolvedores Fullstack** - Arquitetura, Backend e Frontend.


---

## 📝 Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do Trabalho de Conclusão de Curso (TCC).

