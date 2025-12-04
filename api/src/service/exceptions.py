class ImageBasedPDFException(Exception):
    """Raised when PDF is image-based instead of text-based"""
    pass

class NotTranscriptException(Exception):
    """Raised when document is not a university transcript"""
    pass
