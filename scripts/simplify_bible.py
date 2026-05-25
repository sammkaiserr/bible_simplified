#!/usr/bin/env python3
"""
Telugu Bible Simplification - High-Speed Parallel Batch Translator
Uses ThreadPoolExecutor to translate multiple books in parallel,
populating all 66 books of the Bible in under 1-2 minutes!
"""

import json
import os
import sys
import time
import requests
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

# Config paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "assets", "bible")
BBE_CACHE_FILE = os.path.join(SCRIPT_DIR, "en_bbe.json")
PROGRESS_FILE = os.path.join(SCRIPT_DIR, "progress.json")
BBE_URL = "https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_bbe.json"

# Standard order of the 66 books of the Bible
STANDARD_BOOKS = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
    '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Songs',
    'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah',
    'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians',
    '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
    '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
    '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'
]

SEPARATOR = " ||| "
MAX_CHAR_LIMIT = 4000
progress_lock = threading.Lock()
print_lock = threading.Lock()

def safe_print(message):
    """Thread-safe printing."""
    with print_lock:
        print(message)
        sys.stdout.flush()

def download_bbe_if_needed():
    """Ensure the en_bbe.json file is cached locally."""
    if not os.path.exists(BBE_CACHE_FILE):
        safe_print("Downloading Bible in Basic English (BBE) dataset...")
        try:
            resp = requests.get(BBE_URL, timeout=30)
            resp.raise_for_status()
            content = resp.content.decode('utf-8-sig')
            with open(BBE_CACHE_FILE, 'w', encoding='utf-8') as f:
                f.write(content)
            safe_print("BBE dataset downloaded and cached successfully.")
        except Exception as e:
            safe_print(f"Error downloading BBE dataset: {e}")
            sys.exit(1)

def load_progress():
    """Load progress tracking file with thread-safety."""
    with progress_lock:
        if os.path.exists(PROGRESS_FILE):
            with open(PROGRESS_FILE, 'r') as f:
                try:
                    progress = json.load(f)
                    if "completed_books" not in progress:
                        progress["completed_books"] = []
                    return progress
                except Exception:
                    pass
        return {"completed_books": []}

def save_progress(progress):
    """Save progress tracking file with thread-safety."""
    with progress_lock:
        with open(PROGRESS_FILE, 'w') as f:
            json.dump(progress, f, indent=3)

def translate_single_string(text):
    """Translate a single string using Google Translate free API endpoint."""
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        "client": "gtx",
        "sl": "en",
        "tl": "te",
        "dt": "t",
        "q": text
    }
    for attempt in range(5):
        try:
            resp = requests.get(url, params=params, timeout=10)
            if resp.status_code == 200:
                data = resp.json()
                translated = "".join(segment[0] for segment in data[0] if segment[0])
                return translated
            elif resp.status_code == 429:
                time.sleep(2)
            else:
                time.sleep(1)
        except Exception:
            time.sleep(1)
    return None

def translate_verses_slow(english_texts):
    """Fallback: Translate one-by-one using Google Translate free API endpoint."""
    results = []
    for text in english_texts:
        res = translate_single_string(text)
        results.append(res or "")
        time.sleep(0.1)
    return results

def translate_verses_fast(english_texts):
    """Translate a list of verses in ultra-fast chunked separator mode."""
    if not english_texts:
        return []

    # Chunk the verses to stay below character limit
    chunks = []
    current_chunk = []
    current_length = 0

    for text in english_texts:
        added_len = len(text) + len(SEPARATOR)
        if current_length + added_len > MAX_CHAR_LIMIT and current_chunk:
            chunks.append(current_chunk)
            current_chunk = [text]
            current_length = len(text)
        else:
            current_chunk.append(text)
            current_length += added_len
            
    if current_chunk:
        chunks.append(current_chunk)

    final_results = []

    for chunk_idx, chunk in enumerate(chunks):
        joined_text = SEPARATOR.join(chunk)
        translated_joined = translate_single_string(joined_text)

        if translated_joined:
            parts = [p.strip() for p in translated_joined.split("|||")]
            if len(parts) == len(chunk):
                final_results.extend(parts)
            else:
                slow_parts = translate_verses_slow(chunk)
                final_results.extend(slow_parts)
        else:
            slow_parts = translate_verses_slow(chunk)
            final_results.extend(slow_parts)

    return final_results

def process_book(book_idx, book_name, bbe_book):
    """Process a single book, translating missing verses using fast chunked translation."""
    filepath = os.path.join(ASSETS_DIR, f"{book_name}.json")
    if not os.path.exists(filepath):
        safe_print(f"  ✗ File not found: {filepath}")
        return book_name, False

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        safe_print(f"  ✗ Error reading {book_name}.json: {e}")
        return book_name, False

    safe_print(f"📖 [{book_idx+1}/66] Started: {book_name}")
    modified = False

    for ch_idx, chapter in enumerate(data["chapters"]):
        chapter_num = chapter["chapter"]
        verses = chapter["verses"]

        needs_translation = []
        english_texts = []

        for v in verses:
            verse_num = int(v["verse"])
            if "simpleText" not in v or not v["simpleText"]:
                english_text = ""
                try:
                    # Handle special mismatches
                    if book_name == "Psalms" and chapter_num == 76:
                        english_text = bbe_book["chapters"][75][verse_num]
                    elif book_name == "3 John" and chapter_num == 1 and verse_num == 14:
                        english_text = bbe_book["chapters"][0][13] + " " + bbe_book["chapters"][0][14]
                    else:
                        english_text = bbe_book["chapters"][ch_idx][verse_num - 1]
                except IndexError:
                    pass

                # Check if English text is omitted or invalid in BBE
                clean_eng = english_text.strip()
                if not clean_eng or clean_eng in ("[]", "***", "()", "[ ]") or not any(c.isalnum() for c in clean_eng):
                    v["simpleText"] = v["text"]  # Fallback to original Telugu text
                    modified = True
                else:
                    needs_translation.append(v)
                    english_texts.append(english_text)

        # Translate in fast chunked mode
        if needs_translation:
            translated_texts = translate_verses_fast(english_texts)

            if translated_texts and len(translated_texts) == len(needs_translation):
                book_has_failures = False
                for v, telugu_text in zip(needs_translation, translated_texts):
                    clean_telugu = telugu_text.strip()
                    if clean_telugu:
                        v["simpleText"] = clean_telugu
                        modified = True
                    else:
                        book_has_failures = True
                
                if book_has_failures:
                    safe_print(f"    ✗ {book_name} Ch.{chapter_num}: Some verses failed to translate (returned empty)")
                    if modified:
                        try:
                            with open(filepath, 'w', encoding='utf-8') as f:
                                json.dump(data, f, ensure_ascii=False, indent=3)
                        except Exception:
                            pass
                    return book_name, False
            else:
                safe_print(f"    ✗ {book_name} Ch.{chapter_num}: FAILED translation mismatch")
                return book_name, False

    # Save once after the entire book is finished to avoid lock contentions
    if modified:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=3)
        except Exception as e:
            safe_print(f"  ✗ Error saving {book_name}.json: {e}")
            return book_name, False

    safe_print(f"✅ {book_name} COMPLETE!")
    return book_name, True

def main():
    print("=" * 60)
    print("Telugu Bible Simplification - Parallel Batch Translator")
    print("=" * 60)
    
    download_bbe_if_needed()
    
    # Load cached BBE database
    with open(BBE_CACHE_FILE, 'r', encoding='utf-8') as f:
        bbe_data = json.load(f)
    
    # Collect books to process by checking actual JSON files for missing translations
    books_to_process = []
    for idx, book_name in enumerate(STANDARD_BOOKS):
        filepath = os.path.join(ASSETS_DIR, f"{book_name}.json")
        needs_translation = False
        
        if not os.path.exists(filepath):
            needs_translation = True
        else:
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                for chapter in data.get("chapters", []):
                    for v in chapter.get("verses", []):
                        if "simpleText" not in v or not v["simpleText"]:
                            needs_translation = True
                            break
                    if needs_translation:
                        break
            except Exception:
                needs_translation = True
                
        if needs_translation:
            books_to_process.append((idx, book_name, bbe_data[idx]))
            
    if not books_to_process:
        print("\n🎉 ALL 66 BOOKS OF THE BIBLE FULLY SIMPLIFIED AND VERIFIED!")
        sys.exit(0)

    print(f"Launching parallel translator with 45 worker threads for {len(books_to_process)} books...")
    
    start_time = time.time()
    
    # Execute translations in parallel
    with ThreadPoolExecutor(max_workers=45) as executor:
        futures = {
            executor.submit(process_book, idx, name, bbe): name 
            for idx, name, bbe in books_to_process
        }
        
        for future in as_completed(futures):
            book_name = futures[future]
            try:
                name, success = future.result()
                if success:
                    # Update progress in a thread-safe way
                    progress = load_progress()
                    if name not in progress["completed_books"]:
                        progress["completed_books"].append(name)
                    save_progress(progress)
                else:
                    safe_print(f"❌ {book_name} failed translation. Please rerun the script later.")
            except Exception as e:
                safe_print(f"❌ Thread exception for {book_name}: {e}")

    duration = time.time() - start_time
    print("\n" + "=" * 60)
    print(f"🎉 PARALLEL TRANSLATION RUN COMPLETED in {duration:.1f} seconds!")
    print("=" * 60)

if __name__ == "__main__":
    main()

