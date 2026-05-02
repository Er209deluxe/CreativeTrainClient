package Creative.train.Managers;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.Result;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.QRCodeReader;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import org.springframework.web.multipart.MultipartFile;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import javax.imageio.ImageIO;

public class QrManager {

    // Method to generate QR code
    public static BufferedImage generateQrCode(String text) throws WriterException {
        int width = 300;
        int height = 300;

        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        BitMatrix bitMatrix = qrCodeWriter.encode(text, BarcodeFormat.QR_CODE, width, height);

        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                image.setRGB(x, y, bitMatrix.get(x, y) ? 0x000000 : 0xFFFFFF);
            }
        }

        System.out.println("QR Code generated!");
        return image;
    }

    /**
     * This method decodes a QR code from a BufferedImage.
     * It creates a LuminanceSource from the BufferedImage and converts it into a BinaryBitmap.
     * Then it decodes the QR code using QRCodeReader.
     *
     * @param image The BufferedImage containing the QR code to decode.
     * @return The decoded text from the QR code.
     * @throws Exception If any error occurs during decoding the QR code.
     */
    public static String readQrCode(BufferedImage image) throws Exception {
        try {
            // Convert BufferedImage to LuminanceSource
            BufferedImageLuminanceSource luminanceSource = new BufferedImageLuminanceSource(image);

            // Use HybridBinarizer to convert the LuminanceSource into a BinaryBitmap
            HybridBinarizer binarizer = new HybridBinarizer(luminanceSource);

            // Create BinaryBitmap from the binarizer
            BinaryBitmap binaryBitmap = new BinaryBitmap(binarizer);

            // Use QRCodeReader to decode the BinaryBitmap
            QRCodeReader qrCodeReader = new QRCodeReader();
            Result result = qrCodeReader.decode(binaryBitmap);

            // Return the decoded text from the QR code
            return result.getText();
        } catch (Exception e) {
            // Catching any decoding errors and printing the exception for better error handling
            throw new Exception("Error decoding the QR code: " + e.getMessage(), e);
        }
    }

    // Example method for converting BufferedImage to byte array (for sending over HTTP as image)
    public static byte[] imageToByteArray(BufferedImage image) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);
        return baos.toByteArray();
    }



    // Method to convert MultipartFile to BufferedImage
    public static BufferedImage convertMultipartFileToBufferedImage(MultipartFile file) throws IOException {
        // Convert MultipartFile to BufferedImage
        return ImageIO.read(file.getInputStream());
    }
}