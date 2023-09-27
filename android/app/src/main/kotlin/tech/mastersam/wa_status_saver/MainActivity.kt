package tech.mastersam.wa_status_saver

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data) // Call super

        // Handle the result of the activity here if needed
        // ...
    }
}
