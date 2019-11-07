
#if !defined(__lock_h)     // Sentry, use file only if it's not already included.
#define __lock_h

void TMYDCHUB_LOCK_CREATE ();		// initialize lock
void TMYDCHUB_LOCK_DELETE ();		// delete lock
void TMYDCHUB_LOCK ();				// lock TMyDCHub struct for read/write
void TMYDCHUB_UNLOCK ();			// unlock it.


void RECVMYDC_LOCK_CREATE ();
void RECVMYDC_LOCK_DELETE ();
void RECVMYDC_LOCK ();
void RECVMYDC_UNLOCK ();


#endif
