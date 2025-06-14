import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../services/user_data_manage/user_data_manage.dart';

class PdfInvoiceGenerator {
  static Future<void> generateInvoice(UserService userService) async {
    final pdf = pw.Document();

    // Charger une police pour supporter les caractères spéciaux
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(boldFont),
              pw.SizedBox(height: 30),
              
              // Informations utilisateur
              _buildUserInfo(userService, font, boldFont),
              pw.SizedBox(height: 30),
              
              // Détails de consommation
              _buildConsumptionDetails(userService, font, boldFont),
              pw.SizedBox(height: 30),
              
              // Tableau de facturation
              _buildBillingTable(userService, font, boldFont),
              pw.SizedBox(height: 30),
              
              // Pied de page
              _buildFooter(font),
            ],
          );
        },
      ),
    );

    // Sauvegarder et ouvrir le PDF
    await _savePdf(pdf);
  }

  static pw.Widget _buildHeader(pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#38b000'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FACTURE ÉNERGÉTIQUE',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Smart Meter App - Suivi de consommation',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildUserInfo(UserService userService, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMATIONS CLIENT',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nom:', userService.displayName, font, boldFont),
                  _buildInfoRow('Email:', userService.userData?['email'] ?? 'N/A', font, boldFont),
                  _buildInfoRow('Adresse:', userService.userData?['address'] ?? 'N/A', font, boldFont),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('N° Compteur:', userService.userData?['meterNumber'] ?? 'N/A', font, boldFont),
                  _buildInfoRow('Fournisseur:', userService.userData?['electricityProvider'] ?? 'N/A', font, boldFont),
                  _buildInfoRow('Plan tarifaire:', userService.userData?['tariffPlan'] ?? 'N/A', font, boldFont),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildConsumptionDetails(UserService userService, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DÉTAILS DE CONSOMMATION',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildConsumptionCard('Puissance actuelle', '${userService.currentPower.toStringAsFixed(1)} kW', font, boldFont),
              _buildConsumptionCard('Énergie consommée', '${userService.energie.toStringAsFixed(1)} kWh', font, boldFont),
              _buildConsumptionCard('Tension', '${userService.tension.toStringAsFixed(1)} V', font, boldFont),
              _buildConsumptionCard('Courant', '${userService.courant.toStringAsFixed(1)} A', font, boldFont),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBillingTable(UserService userService, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FACTURATION',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableCell('Description', boldFont, isHeader: true),
                  _buildTableCell('Quantité', boldFont, isHeader: true),
                  _buildTableCell('Prix unitaire', boldFont, isHeader: true),
                  _buildTableCell('Total', boldFont, isHeader: true),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Consommation électrique', font),
                  _buildTableCell('${userService.energie.toStringAsFixed(1)} kWh', font),
                  _buildTableCell('${(userService.cout / userService.energie).toStringAsFixed(0)} FCFA/kWh', font),
                  _buildTableCell('${userService.cout.toStringAsFixed(0)} FCFA', font),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#38b000'),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'TOTAL: ${userService.cout.toStringAsFixed(0)} FCFA',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 16,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Cette facture a été générée automatiquement par Smart Meter App',
            style: pw.TextStyle(font: font, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Pour toute question, contactez notre support technique',
            style: pw.TextStyle(font: font, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: pw.TextStyle(font: boldFont, fontSize: 10)),
          ),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildConsumptionCard(String title, String value, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 8)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf) async {
    try {
      // Afficher l'aperçu et permettre l'impression/sauvegarde
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'facture_energie_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde du PDF: $e');
    }
  }
}