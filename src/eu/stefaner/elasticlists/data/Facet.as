/*
   
Copyright 2010, Moritz Stefaner

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
   
 */

package eu.stefaner.elasticlists.data {	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**	 * 	Facet 	 * 	 * 	represents a field of the data used for filtering	 * 	manages a collection of FacetValues	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 */	
	public class Facet extends EventDispatcher {

		public static const GEO : String = "GEO";
		public var model : Model;		public var label : String;		public var name : String;		public var facetValues : Array;		protected var facetValuesByName : Dictionary;		// to be moved in facetbox? (more a display thing)		public var sortOptions : uint = Array.NUMERIC | Array.DESCENDING;		public var sortFields : Array = ["selected", "numContentItems", "totalNumContentItems", "label"];
		public var filter : Filter = new Filter();

		//---------------------------------------		// CONSTRUCTOR		//---------------------------------------		public function Facet(name : String = "", label : String = null) {			this.name = name;			this.label = label ? label : name;						facetValuesByName = new Dictionary(true);			facetValues = [];		}

		override public function toString() : String {			return("[Object Facet name: " + name + " label: " + label + " children: " + facetValues.length + "]");		};

		//---------------------------------------		// GETTER / SETTERS		//---------------------------------------		// calculates totalNumContentItems and globalRatio		// (reflecting a priori / unfiltered distribution)		// for facetValues		public function calcGlobalStats() : void {						var max : Number = 0;			var f : FacetValue;						for each(f in facetValues) {				f.totalNumContentItems = model.getTotalNumContentItemsForFacetValue(f);				max = Math.max(f.totalNumContentItems, max);			}						// second run: set ratio values			for each(f in facetValues) {				f.globalRatio = f.totalNumContentItems / max;				f.globalPercentage = f.totalNumContentItems / model.allContentItems.length; 			}			sortFacetValues();		};		

		// calculates numContentItems and localRatio		// (reflecting a filtered distribution)		// for facetValues		public function calcLocalStats() : void {			var f : FacetValue;			var max : Number = -1;						for each(f in facetValues) {				f.numContentItems = model.getFilteredNumContentItemsForFacetValue(f);				max = Math.max(f.numContentItems, max);			}						// second run: set ratio values			for each(f in facetValues) {				f.localRatio = f.numContentItems / max;				f.localPercentage = f.numContentItems / model.filteredContentItems.length;
				f.distinctiveness = Math.log(f.localPercentage / f.globalPercentage);			}						sortFacetValues();		};

		protected function sortFacetValues() : void {			if(sortFields.length) {				facetValues.sortOn(sortFields, sortOptions);			}		}

		protected function compareFacetValues(a : FacetValue,b : FacetValue) : int {						// selected items to top			if (a.selected && !b.selected) {				return -1;			}			if (!a.selected && b.selected) {				return 1;			}						// sort by numContentItems			if (a.numContentItems < b.numContentItems) {				return 1;			} 			if (a.numContentItems > b.numContentItems) {				return -1;			}						// sort by totalNumContentItems			if (a.totalNumContentItems > b.totalNumContentItems) {				return -1;			} 			if (a.totalNumContentItems < b.totalNumContentItems) {				return 1;			}						// sort by name			if (a.label > b.label) {				return 1;			} 			if (a.label < b.label) {				return 1;			}						return 0;		}

		//---------------------------------------		// FACET VALUES		//---------------------------------------		public function addFacetValue(f : FacetValue) : void {			facetValues.push(f);			facetValuesByName[f.name] = f;		}

		public function createFacetValue(name : String) : FacetValue {			if(hasFacetValueWithName(name)) {				return facetValue(name);			}			var f : FacetValue = new FacetValue(name);			addFacetValue(f);							return f;		};

		public function facetValue(name : String) : FacetValue {			return facetValuesByName[name];		};

		public function hasFacetValueWithName(name : String) : Boolean {			return Boolean(facetValue(name));		}

		public function getSelectedFacetValues() : Array {			var result : Array = [];			for each(var facetValue:FacetValue in facetValues) {				if(facetValue.selected) {					result.push(facetValue);				}			}			return result;		}				
		public function updateContentItemFilter() : Filter {
			filter.clear();
			for each(var facetValue:FacetValue in facetValues) {
				if(facetValue.selected){
					filter.add(facetValue);
				}
			}
			return filter;
		}	
	}}