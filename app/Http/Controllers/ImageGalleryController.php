<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ImageGalleryController extends Controller
{
    public function __construct()
    {
        \Unsplash\HttpClient::init([
            'applicationId' => config('services.unsplash.access_key'),
            'secret' => config('services.unsplash.secret_key'),
            'utmSource' => config('services.unsplash.app_name')
        ]);
    }

    public function index()
    {
        return $this->showGallery('cats', 10, 'landscape');
    }

    public function search(Request $request)
    {
        return $this->showGallery($request->search, $request->count, $request->orientation);
    }

    private function showGallery($search, $count, $orientation)
    {
        $page = 1;
        $collections = "";

        $results = \Unsplash\Search::photos($search, $page, $count, $orientation, $collections);
        $images = $results->getResults();
        return view('image-gallery', compact('images', 'search', 'count', 'orientation'));
    }
}
