package com.projeto.tcc.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Async
    public void sendCaregiverReport(String toEmail, String caregiverName, String userName, String reportContent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(toEmail);
            helper.setSubject("VivaBem+ | Relatório Diário de " + userName);

            String htmlBody = String.format("""
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        h2 { color: #2c3e50; }
                        h3 { color: #34495e; margin-top: 20px; }
                        .report-content { background-color: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #3498db; }
                        hr { border: 0; height: 1px; background: #ddd; margin: 20px 0; }
                        .footer { font-size: 12px; color: #7f8c8d; margin-top: 30px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h2>Olá, %s!</h2>
                        <p>Aqui está o relatório diário de saúde de <strong>%s</strong>.</p>
                        <hr/>
                        <div class="report-content">
                            %s
                        </div>
                        <hr/>
                        <p class="footer"><em>Este é um e-mail automático do sistema VivaBem+.</em></p>
                    </div>
                </body>
                </html>
                """, caregiverName, userName, reportContent);

            helper.setText(htmlBody, true);
            mailSender.send(message);

            System.out.println("📧 E-mail enviado com sucesso para o cuidador: " + toEmail);

        } catch (MessagingException e) {
            System.err.println("❌ Erro ao enviar e-mail: " + e.getMessage());
            e.printStackTrace();
        }
    }
}